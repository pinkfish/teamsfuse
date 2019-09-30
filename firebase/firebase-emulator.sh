#!/bin/sh

if [ $# -eq 0 ]; then
    echo "firebase-emulator {start|stop}"
    exit 1
fi

EMULATOR="cloud-firestore-emulator"
EMULATOR_TARGET=$(find ~/.cache/firebase/emulators/ -type f -name "$EMULATOR*.jar" | sort -r | head -n1)

if [ -z "$EMULATOR_TARGET" ]; then
  echo "Could not find the firestore emulator. Ending test run."
  exit 1
fi

# I've found that the java process is not always killed properly,
# causing issues on subsequent runs... so let's clean things up when we're done (or have errored)
killEmulatorPid()
{
  EMULATOR_PID=$(pgrep -f "$EMULATOR")

  if ! [ -z "$EMULATOR_PID" ]; then
    kill -9 "$EMULATOR_PID"
  fi
}

startEmulator()
{
  java -jar "$EMULATOR_TARGET" --host=127.0.0.1 --port=9090 > /dev/null 2> firestore-emulator.log &
  RETRIES=0
  RETRY_LIMIT=10

  while [ $RETRIES -lt $RETRY_LIMIT ]; do
    sleep 1
    echo "Pinging firestore emulator"

    if nc -z localhost 9090; then
      break
    fi

    let RETRIES+=1

    if [ $RETRIES -ge $RETRY_LIMIT ]; then
      echo "Could not find the firestore emulator. Ending test run."
      killEmulatorPid
      exit 1
    fi
  done
}

case $1 in
  start)
    echo "Starting the emulator"
    startEmulator
    exit 0
  stop)
    echo "Stopping the emulator"
    killEmulatorPid
    exit 0
  *)
    echo "firebase-emulator {start|stop}"
    exit 1
esac

echo "End of test run. Cleaning up the firestore emulator."
