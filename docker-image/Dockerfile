# Use the official Ubuntu base image
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts during apt-get install
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    libpq-dev \
    vim \
    postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create and set the working directory
WORKDIR /app

# Copy the Python script and requirements file
COPY app.py /app/
COPY templates /app/templates/

# Install Python dependencies
RUN pip3 install --no-cache-dir kubernetes Flask psycopg2-binary

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python3", "app.py"]