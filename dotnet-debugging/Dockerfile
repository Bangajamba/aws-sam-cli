FROM lambci/lambda:dotnetcore2.1

# Add in VSDBG
# Based on https://github.com/sleemer/docker.dotnet.debug
ENV NUGET_XMLDOC_MODE skip
WORKDIR /vsdbg
RUN yum update \
    && yum install -y unzip \
    && curl -sSL https://aka.ms/getvsdbgsh | bash /dev/stdin -v latest -l /vsdbg

# Sleep until a debugger is attached
ENTRYPOINT ["/bin/bash", "-c", "sleep infinity"]

# ENTRYPOINT ["/var/lang/bin/dotnet", "/var/runtime/MockBootstraps.dll"]
