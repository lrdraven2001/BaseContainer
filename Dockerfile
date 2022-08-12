ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/redhat/openjdk/openjdk11
ARG BASE_TAG=1.11

FROM tomcat:9.0.65-jdk11-openjdk AS base


FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}
ENV PATH /usr/local/tomcat/bin:$PATH

COPY --from=base /usr/local/tomcat/ /usr/local/tomcat/

COPY scripts/catalina.sh /usr/local/tomcat/bin

USER 0
RUN chmod +x /usr/local/tomcat/bin/catalina.sh &&\
    chmod o-w /usr/local/tomcat/bin/catalina.sh

RUN df --local -P | awk '{if (NR!=1) print $6}' \
    | xargs -I '{}' find '{}' -xdev -type d \
    \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null \
    | xargs chmod a+t


WORKDIR /usr/local/tomcat/bin

USER 1001
EXPOSE 8080

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=1m --retries=5 CMD curl -I -f --max-time 5 http://localhost:8080 || exit 1

