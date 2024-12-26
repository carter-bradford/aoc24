#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

char* readFileToString(const char* filename) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("Failed to open file");
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);

    char *buffer = (char*)malloc(fileSize + 1);
    if (buffer == NULL) {
        perror("Failed to allocate memory");
        fclose(file);
        return NULL;
    }

    fread(buffer, 1, fileSize, file);
    buffer[fileSize] = '\0';

    fclose(file);
    return buffer;
}

typedef struct {
    int* dataBlocks;
    int* freeBlocks;
    int lengthData;
    int lengthFree;
} DiskmapResult;

typedef struct {
    int id;
    int positionStart;
    bool isFree;
    int length;
} MemoryChunk;

typedef struct {
    MemoryChunk* fileChunks;
    int numFileChunks;
    MemoryChunk* freeChunks;
    int numFreeChunks;
} FilesAndFreeChunks;

DiskmapResult transformDiskmap(const char* diskmap) {
    int diskmapLength = strlen(diskmap);
    int* dataBlocks = (int *)malloc((diskmapLength / 2 + 1)* sizeof(int));;
    int* freeBlocks = (int *)malloc((diskmapLength / 2 + 1)* sizeof(int));;
    int dataBlockId = 0;
    int freeBlockId = 0;

    for(int i = 0; i < diskmapLength; i++) {
        if(i % 2 == 0) {
            dataBlocks[dataBlockId] = diskmap[i] - '0';
            dataBlockId++;
        }
        else {
            freeBlocks[freeBlockId] = diskmap[i] - '0';
            freeBlockId++;
        }
    }

    DiskmapResult result;
    result.dataBlocks = dataBlocks;
    result.lengthData = dataBlockId;
    result.freeBlocks = freeBlocks;
    result.lengthFree = freeBlockId;
    return result;
}

FilesAndFreeChunks zipDiskmap(const int* dataBlocks, int lengthData, const int* freeBlocks, int lengthFree) {
    MemoryChunk* fileMap = (MemoryChunk*)malloc((lengthData) * sizeof(MemoryChunk));
    MemoryChunk* freeMap = (MemoryChunk*)malloc((lengthFree) * sizeof(MemoryChunk));
    //int position = 0;
    int startPosition = 0;
    int numFileChunks = 0;
    int numFreeChunks = 0;

    for(int i = 0; i < lengthData; i++) {
        MemoryChunk fileChunk;
        fileChunk.id = i;
        fileChunk.positionStart = startPosition;
        fileChunk.isFree = false;
        fileChunk.length = dataBlocks[i];
        fileMap[numFileChunks] = fileChunk;
        //position++;
        numFileChunks++;
        startPosition += dataBlocks[i];
        
        if(i < lengthFree) {
            MemoryChunk freeMemoryChunk;
            freeMemoryChunk.id = i;
            freeMemoryChunk.isFree = true;
            freeMemoryChunk.positionStart = startPosition;
            freeMemoryChunk.length = freeBlocks[i];
            freeMap[numFreeChunks] = freeMemoryChunk;
            //position++;
            numFreeChunks++;
            startPosition += freeBlocks[i];
        }       
    }

    FilesAndFreeChunks result;
    result.fileChunks = fileMap;
    result.numFileChunks = numFileChunks;
    result.freeChunks = freeMap;
    result.numFreeChunks = numFreeChunks;
    return result;
}

long calculateChecksum(const int* dataBlocks, int lengthData, const int* freeBlocks) {
    long checksum = 0;
    int checksumPosition = 0;
    int currentFreeBlockPosition = 0;
    int freeBlocksRemaining = freeBlocks[0];
    int forwardPosition = 0;
    printf("Free blocks remaining: %d\n", freeBlocksRemaining);

    // Calculate the checksum value for the first data block
    for (int i = 0; i < dataBlocks[0]; i++) {
        // Checksum for first data block will always be zero since its ID is 0
        checksumPosition++;
    }

    // Iterate from the end of dataBlocks to the second element
    for (int i = lengthData - 1; i > 0; i--) {
        int currentBlockId = i;
        int currentBlockRepeatValue = dataBlocks[i];

        printf("forwardPosition: %d, i: %d\n", forwardPosition, i);

        if (forwardPosition >= i) {
            break;
        }

        if(freeBlocksRemaining == 0) {
            forwardPosition++;
            
            int forwardBlockRepeatValue = dataBlocks[forwardPosition];
            for(int j = 0; j < forwardBlockRepeatValue; j++) {
                printf("Adding to checksum (forward) %d * %d\n", forwardPosition, checksumPosition);
                checksum += forwardPosition*checksumPosition;
                checksumPosition++;
            }
            currentFreeBlockPosition++;
            freeBlocksRemaining = freeBlocks[currentFreeBlockPosition];
        }
        
        if(currentBlockRepeatValue <= freeBlocksRemaining) {
            freeBlocksRemaining -= currentBlockRepeatValue;
            printf("Free blocks remaining: %d\n", freeBlocksRemaining);
            for(int j = 0; j < currentBlockRepeatValue; j++) {
                printf("Adding to checksum %d * %d\n", i, checksumPosition);
                checksum += i*checksumPosition;
                checksumPosition++;
            }
        }
        else {
            int remainingBlocks = currentBlockRepeatValue;
            while (remainingBlocks > 0) {
                // Move as much as we can
                int blocksToMove = freeBlocksRemaining;
                for(int j = 0; j < blocksToMove; j++) {
                    printf("Adding to checksum (partial) %d * %d\n", i, checksumPosition);
                    checksum += i*checksumPosition;
                    checksumPosition++;
                    remainingBlocks--;
                    freeBlocksRemaining--;
                    if(remainingBlocks == 0) {
                        break;
                    }
                }

                if (remainingBlocks == 0 && freeBlocksRemaining > 0)
                    break;
                
                forwardPosition++;

                if(forwardPosition >= i) {
                    currentFreeBlockPosition++;
                    freeBlocksRemaining = freeBlocks[currentFreeBlockPosition]; 
                    continue;
                }
                // Process the next datablock at forward position
                int forwardBlockRepeatValue = dataBlocks[forwardPosition];
                for(int j = 0; j < forwardBlockRepeatValue; j++) {
                    printf("Adding to checksum (forward) %d * %d\n", forwardPosition, checksumPosition);
                    checksum += forwardPosition*checksumPosition;
                    checksumPosition++;
                }

                currentFreeBlockPosition++;
                freeBlocksRemaining = freeBlocks[currentFreeBlockPosition];    
            }
        }

    }
    
    return checksum;
}

long calculateChecksumPart2(const int* dataBlocks, int lengthData, const int* freeBlocks, int lengthFree) {
    FilesAndFreeChunks zippedDiskmap = zipDiskmap(dataBlocks, lengthData, freeBlocks, lengthFree);
    
    long checksum = 0;
    for (int i = zippedDiskmap.numFileChunks - 1; i > 0; i--) {
        printf("Starting chunk index: %d\n", i);
        MemoryChunk* chunk = &zippedDiskmap.fileChunks[i];
        for (int k = 0; k < zippedDiskmap.numFreeChunks; k++) {
            MemoryChunk* freeChunk = &zippedDiskmap.freeChunks[k];
            if(freeChunk->positionStart > chunk->positionStart) {
                break;
            }
            if (freeChunk->length >= chunk->length) {
                printf("Moving chunk id %d to position %d\n", chunk->id, freeChunk->positionStart);
                chunk->positionStart = freeChunk->positionStart;
                freeChunk->length -= chunk->length;
                freeChunk->positionStart += chunk->length;
                break;
            }
        }
    }
    
    for (int i = 0; i < zippedDiskmap.numFileChunks; i++) {
        MemoryChunk chunk = zippedDiskmap.fileChunks[i];
        int startingPosition = chunk.positionStart;
        for(int j = 0; j < chunk.length; j++) {
            checksum += startingPosition * chunk.id;
            startingPosition++;
        }
    }
    return checksum;
}

int main() {
    const char *filename = "diskmap.txt";
    char *fileContents = readFileToString(filename);

    if (fileContents == NULL) {
        printf("Couldn't parse the file.  Sorry man.");
        return -1;
    }

    DiskmapResult transformedDiskmap = transformDiskmap(fileContents);
    printf("Data blocks:\n");
    for (int i = 0; i < transformedDiskmap.lengthData; i++) {
        printf("%d ", transformedDiskmap.dataBlocks[i]);
    }
    printf("\n");

    printf("Free blocks:\n");
    for (int i = 0; i < transformedDiskmap.lengthFree; i++) {
        printf("%d ", transformedDiskmap.freeBlocks[i]);
    }
    printf("\n");

    // if (transformedDiskmap.dataBlocks != NULL) {
    //     long checksum = calculateChecksum(transformedDiskmap.dataBlocks, transformedDiskmap.lengthData, transformedDiskmap.freeBlocks);
    //     printf("Checksum: %ld\n", checksum);
    // }

    long checksumPart2 = calculateChecksumPart2(transformedDiskmap.dataBlocks, transformedDiskmap.lengthData, transformedDiskmap.freeBlocks, transformedDiskmap.lengthFree);
    printf("Checksum Part 2: %ld\n", checksumPart2);

    free(transformedDiskmap.dataBlocks);
    free(transformedDiskmap.freeBlocks);
    free(fileContents);
    
    return 0;
}