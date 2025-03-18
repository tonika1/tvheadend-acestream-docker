FROM python:3

WORKDIR /usr/src/app

COPY config/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Entry point for the container.
COPY config/your-daemon-or-script.py ./

CMD [ "python", "./your-daemon-or-script.py" ]
