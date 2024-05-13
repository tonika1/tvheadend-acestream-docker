#!/bin/bash

# Start the Acestream engine
#exec /opt/acestream/start-engine "@/opt/acestream/acestream.conf"
exec /opt/acestream/start-engine --client-console --live-cache-type memory

