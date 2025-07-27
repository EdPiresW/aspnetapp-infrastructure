ARG BASE_IMAGE=mcr.microsoft.com/dotnet/samples:aspnetapp
FROM ${BASE_IMAGE} AS final
# Nada a copiar — imagem base já tem a aplicação.
ENTRYPOINT ["dotnet", "aspnetapp.dll"]
