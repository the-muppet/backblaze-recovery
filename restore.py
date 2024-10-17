import os
import sys
import time
from b2sdk.v2 import InMemoryAccountInfo, B2Api, parse_folder, ScanPoliciesManager, Synchronizer, SyncReport, BasicSyncEncryptionSettingsProvider, EncryptionSetting, EncryptionMode

def setup_b2_api():
    info = InMemoryAccountInfo()
    b2_api = B2Api(info)
    application_key_id = os.environ.get('APPLICATION_KEY_ID')
    application_key = os.environ.get('APPLICATION_KEY')
    if not application_key_id or not application_key:
        raise ValueError("APPLICATION_KEY_ID and APPLICATION_KEY must be set in environment variables")
    b2_api.authorize_account("production", application_key_id, application_key)
    return b2_api

def sync_from_b2(b2_api, bucket_name, local_folder):
    source = f'b2://{bucket_name}'
    destination = local_folder

    source = parse_folder(source, b2_api)
    destination = parse_folder(destination, b2_api)

    policies_manager = ScanPoliciesManager(exclude_all_symlinks=True)

    synchronizer = Synchronizer(
        max_workers=10,
        policies_manager=policies_manager,
        dry_run=False,
        allow_empty_source=True,
    )

    no_progress = False
    encryption_settings_provider = BasicSyncEncryptionSettingsProvider({
        bucket_name: EncryptionSetting(mode=EncryptionMode.SSE_B2),
    })

    with SyncReport(sys.stdout, no_progress) as reporter:
        synchronizer.sync_folders(
            source_folder=source,
            dest_folder=destination,
            now_millis=int(round(time.time() * 1000)),
            reporter=reporter,
            encryption_settings_provider=encryption_settings_provider,
        )

def download_single_file(b2_api, bucket_name, file_id, local_path):
    bucket = b2_api.get_bucket_by_name(bucket_name)
    file_info = bucket.download_file_by_id(file_id)
    
    with open(local_path, 'wb') as f:
        b2_api.download_file_by_id(file_id, f)
    
    print(f"File downloaded successfully to {local_path}")
    print(f"File name: {file_info.file_name}")
    print(f"File size: {file_info.size} bytes")

def main():
    if len(sys.argv) < 4:
        print("Usage:")
        print("  For full sync: python restore.py full <bucket_name> <local_folder>")
        print("  For single file: python restore.py single <bucket_name> <file_id> <file_name> <local_folder>")
        sys.exit(1)

    restore_type = sys.argv[1]
    bucket_name = sys.argv[2]

    b2_api = setup_b2_api()

    if restore_type == "full":
        local_folder = sys.argv[3]
        print(f"Starting sync from B2 bucket '{bucket_name}' to local folder '{local_folder}'")
        sync_from_b2(b2_api, bucket_name, local_folder)
        print("Sync completed successfully")
    elif restore_type == "single":
        file_id = sys.argv[3]
        file_name = sys.argv[4]
        local_folder = sys.argv[5]
        local_path = os.path.join(local_folder, file_name)
        print(f"Downloading file with ID '{file_id}' from bucket '{bucket_name}' to '{local_path}'")
        download_single_file(b2_api, bucket_name, file_id, local_path)
    else:
        print("Invalid restore type. Use 'full' for full sync or 'single' for single file download.")
        sys.exit(1)

if __name__ == "__main__":
    main()