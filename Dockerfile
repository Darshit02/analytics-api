FROM python:3.14.3-slim-trixie 

# setup linux package

# create a VE
RUN python -m venv /opt/venv
# set the VE as the current location
ENV PATH=/opt/venv/bin:$PATH

# Upgrade pip 
RUN pip install --upgrade pip

# set python-related environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFRED 1

# install os deps for mini vm
RUN apt-get update && apt-get install -y \
    # postgres
    libpq-dev \
    # pillow
    libjpeg-dev \
    #Cairo SVG
    libcairo2 \
    #other
    gcc \
    && rm -rf /var/lib/apt/lists/*

# create  the mini vm's code directory
RUN mkdir -p /code

#set the working directory to the same code directory
WORKDIR /code 

#copy the requirement 
COPY requirement.txt /tmp/requirement.txt


#copy the code  into container's WD
COPY ./src  /code

# install project requirements
RUN pip install -r /tmp/requirements.txt

# make the bash script executable
COPY ./boot/docker-run.sh /opt/run.sh
RUN chmod +x /opt/run.sh

# Clean up apt cache to reduce image size
RUN apt-get remove --purge -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Run the FastAPI project via the runtime script
# when the container starts
CMD ["/opt/run.sh"]



