#ifndef VEC_H
#define VEC_H

typedef struct FileNameVector {
	int size;
	int capacity;
	char** data;
}FileNameVector;


void initVector(FILE* fpMsg, FILE* fpLog, FileNameVector* v);
void pushBackVector(FILE* fpMsg, FILE* fpLog, FileNameVector* v, char* elem);
void removeAt(FILE* fpMsg, FILE* fpLog, FileNameVector* v, int index);
void fillFileVector(FILE* fpMsg, FILE* fpLog, const char* newFolder, FileNameVector* fileVector);

#endif
