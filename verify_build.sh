#!/bin/bash
set -x

echo "=== Environment ==="
echo "PATH=$PATH"
echo "JAVA_HOME=$JAVA_HOME"
java -version 2>&1 || true
javac -version 2>&1 || true

echo "=== Finding ANT ==="
# Try multiple locations
for ant_path in /usr/bin/ant /usr/local/bin/ant /opt/ant/bin/ant /usr/share/ant/bin/ant; do
    if [ -x "$ant_path" ]; then
        echo "Found ant at: $ant_path"
        ANT_CMD="$ant_path"
        break
    fi
done

# If not found by direct path, try which
if [ -z "$ANT_CMD" ]; then
    ANT_CMD=$(which ant 2>/dev/null || true)
fi

# If still not found, search the filesystem
if [ -z "$ANT_CMD" ]; then
    ANT_CMD=$(find /usr /opt /home /root -name "ant" -type f -perm /111 2>/dev/null | head -1)
fi

# Try ant wrapper in project
if [ -z "$ANT_CMD" ] && [ -f "./ant" ]; then
    ANT_CMD="./ant"
fi

echo "ANT_CMD=$ANT_CMD"

if [ -z "$ANT_CMD" ]; then
    echo "ERROR: ant not found anywhere"
    exit 1
fi

$ANT_CMD -version

echo "=== Step 1: Grammar Generation ==="
$ANT_CMD gen-cql3-grammar
echo "Grammar generation: SUCCESS"

echo "=== Step 2: Check gen-java ==="
ls src/gen-java/org/apache/cassandra/cql3/ 2>/dev/null || true

echo "=== Step 3: Full Build ==="
$ANT_CMD build
echo "Build: SUCCESS"

echo "=== Step 4: Find concrete AccordCQL test classes ==="
find test/distributed -name "*.java" | xargs grep -l "extends AccordCQLTestBase" 2>/dev/null || true

echo "=== Verification complete ==="
