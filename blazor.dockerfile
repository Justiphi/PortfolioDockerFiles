# ---- Stage 1: clone the repo ----
FROM alpine/git AS clone
WORKDIR /src
RUN git clone --depth 1 https://github.com/Justiphi/BlazorPortfolio.git .

# ---- Stage 2: build, publish, and bundle EF migrations ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY --from=clone /src .

# _config.json holds the connection string and isn't in the repo —
# it must sit next to this Dockerfile in your local build context.
COPY _config.json ./_config.json

RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish --no-restore

# dotnet publish only copies files the project explicitly references,
# so _config.json needs to be placed into the published output manually.
COPY _config.json /app/publish/_config.json

# Build a self-contained EF migration bundle
RUN dotnet tool install --global dotnet-ef --version 10.*
RUN dotnet tool restore
ENV PATH="$PATH:/root/.dotnet/tools"
RUN dotnet ef migrations bundle \
    --configuration Release \
    --self-contained \
    -r linux-x64 \
    -o /app/efbundle

# ---- Stage 3: final runtime image ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

COPY --from=build /app/publish .
COPY --from=build /app/efbundle .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh efbundle

ENV ASPNETCORE_URLS=http://+:8000
EXPOSE 8000

ENTRYPOINT ["./entrypoint.sh"]
CMD ["dotnet", "BlazorPortfolio.dll"]