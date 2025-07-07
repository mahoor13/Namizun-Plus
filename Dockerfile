# Use Ubuntu 20.04 as base image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    redis-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create directory structure
WORKDIR /var/www/namizun

# Copy the entire local context
COPY . .

# Create virtual environment and install packages
RUN python3 -m venv /var/www/namizun/venv && \
    . /var/www/namizun/venv/bin/activate && \
    pip install wheel && \
    pip install namizun_core/ namizun_menu/ && \
    deactivate

# Create symlink for namizun command
RUN ln -s /var/www/namizun/else/namizun /usr/local/bin/ && \
    chmod +x /usr/local/bin/namizun

# Configure supervisor
RUN mkdir -p /var/log/supervisor
COPY else/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
