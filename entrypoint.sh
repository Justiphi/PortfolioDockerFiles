#!/bin/sh
set -e

echo "Applying EF Core migrations..."
./efbundle

echo "Starting BlazorPortfolio..."
exec "$@"