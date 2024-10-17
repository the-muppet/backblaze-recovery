# Base image
FROM python:3.9

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y git

# Clone the GitHub repository
RUN git clone https://github.com/the-muppet/backblaze-recovery.git /app/repo

# Install Python dependencies
RUN pip install b2sdk

# Set the default command to execute the script
ENTRYPOINT ["python", "/app/repo/restore.py"]