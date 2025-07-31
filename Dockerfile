ARG BASE_IMAGE=mcr.microsoft.com/dotnet/samples:aspnetapp
FROM ${BASE_IMAGE} AS final

ENTRYPOINT ["dotnet", "aspnetapp.dll"]
