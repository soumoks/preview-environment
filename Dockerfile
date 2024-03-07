ARG WORKDIR=/usr/src/app

FROM python:3.11-bullseye


ARG WORKDIR
# make sure all messages always reach console
ENV PYTHONUNBUFFERED=1

# upgrade pip as root user
RUN pip install --upgrade pip

# create appuser for running python as non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# set user home directory to WORKDIR
RUN usermod -d ${WORKDIR} -m appuser

# creates and sets the working directory
WORKDIR ${WORKDIR}

RUN chown -R appuser:appuser ${WORKDIR}

USER appuser

# set PATH to include user bin directory for installing python packages
ENV PATH="${WORKDIR}/.local/bin:${PATH}"


COPY --chown=appuser:appuser requirements.txt ${WORKDIR}

RUN pip install --user --no-cache-dir -r requirements.txt

COPY --chown=appuser:appuser *.py ${WORKDIR}/

ENTRYPOINT ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8088"]