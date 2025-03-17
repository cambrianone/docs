#!/bin/bash

REPOS=(
    "https://github.com/cambrianone/solana-threshold-signature-program solana-threshold-signature-program dev-2"
    "https://github.com/cambrianone/camb-mvp camb-mvp develop"
)

DOCS_DIR="docs"
ACCESS_TOKEN=$ACCESS_TOKEN  # Use the PAT from environment variables

mkdir -p $DOCS_DIR
cp *.md $DOCS_DIR

for REPO in "${REPOS[@]}"; do
    URL=$(echo $REPO | cut -d' ' -f1)
    NAME=$(echo $REPO | cut -d' ' -f2)
    BRANCH=$(echo $REPO | cut -d' ' -f3)
    REPO_DIR="repos/$NAME"

    # Add the PAT to the repository URL for authentication
    AUTH_URL=$(echo $URL | sed "s|https://|https://$ACCESS_TOKEN@|")

    # Clone or pull the repository
    if [ -d "$REPO_DIR" ]; then
        echo "Pulling updates for $NAME..."
        git -C "$REPO_DIR" pull
    else
        echo "Cloning $NAME..."
        git clone -b "$BRANCH" "$AUTH_URL" "$REPO_DIR"
    fi

    # Copy documentation files
    SRC_DOCS="$REPO_DIR"
    DEST_DOCS="$DOCS_DIR/$NAME"
    if [ -d "$DEST_DOCS" ]; then
        rm -rf "$DEST_DOCS"
    fi
    mkdir -p "$DEST_DOCS"
    rsync -avP --include "*.[Mm][Dd]" --include '*/' --exclude '*' --prune-empty-dirs "$SRC_DOCS/" "$DEST_DOCS"
    # cp -r "$SRC_DOCS" "$DEST_DOCS"
    echo "Copied docs from $NAME to $DEST_DOCS"
done

echo "Documentation aggregation complete!"
