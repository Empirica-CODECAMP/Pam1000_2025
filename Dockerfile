# Base image
FROM ubuntu:24.04

ENV PATH="/opt/venv/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-venv python3-pip \
    r-base \
    curl \
    libodbc2 \
    unixodbc \
    unixodbc-dev \
    build-essential libpython3-dev \
    libssl-dev libcurl4-openssl-dev libxml2-dev zlib1g-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up the virtual environment
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install --upgrade pip

# Set working directory and copy application code
WORKDIR /app
COPY . /app

# Install Python dependencies
COPY requirements.txt /app/
RUN /opt/venv/bin/pip install -r requirements.txt

# Install required R packages
RUN R -e "install.packages(c('dplyr', 'here', 'data.table', 'readr', 'lubridate', 'RODBC', 'reshape', 'stringr', 'openxlsx', 'quantmod', 'ggplot2', 'tools', 'readxl', 'openxlsx2', 'openxlsx', 'httr', 'tidyr', 'rlang'), repos='https://cloud.r-project.org/')"

# Compile Django static files
RUN /opt/venv/bin/python manage.py collectstatic --noinput

# Ensure executable permissions for Gunicorn
RUN chmod +x /opt/venv/bin/gunicorn

# Expose the application's port
EXPOSE 8000

# Default command
CMD ["/opt/venv/bin/gunicorn", "Pam_gmm.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "5","--timeout", "1200" ]
