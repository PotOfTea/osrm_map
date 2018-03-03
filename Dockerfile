FROM osrm/osrm-backend as pre-processing-stage

ARG DATA_DIR
ARG OSM_URL
ARG OSM_PATH
ARG OSM_NAME
ARG OSM_PBF
ARG OSM_OSRM
ENV OSM_NAME_PBF ${OSM_NAME}.${OSM_PBF}
ENV OSM_NAME_OSRM ${OSM_NAME}.${OSM_OSRM}

RUN mkdir ${DATA_DIR} \
    && cd ${DATA_DIR} \
        && wget ${OSM_URL}/${OSM_PATH}/${OSM_NAME_PBF} \
    && osrm-extract -p /opt/car.lua ${DATA_DIR}/${OSM_NAME_PBF} \
    && osrm-partition ${DATA_DIR}/${OSM_NAME_OSRM} \
    && osrm-customize ${DATA_DIR}/${OSM_NAME_OSRM}



FROM osrm/osrm-backend

MAINTAINER ReinisStreics spam_email@gmail.com
LABEL description="Used to run osrm backend application"
LABEL version="1.0"

ARG DATA_DIR
ARG OSM_NAME
ARG OSM_OSRM
ENV OSM_NAME_OSRM ${OSM_NAME}.${OSM_OSRM}

RUN mkdir ${DATA_DIR}
COPY --from=pre-processing-stage ${DATA_DIR} ${DATA_DIR}
WORKDIR ${DATA_DIR}
CMD osrm-routed --algorithm mld ${OSM_NAME_OSRM}