#ifndef FIL_H
#define FIL_H

void renameFileExtBackAndMove(FILE* fpMsg, FILE* fpLog, char* fileName);
void readFilesInFolder(char* projectDir);
FILE* tryOpenKoOk(FILE* fpMsg, FILE* fpLog, char* fileName, char* currDir, char* ext);
FILE* openLogFile(const char* aType, const char* bType);
void writeToLogErr(FILE* fpLog, const char* errorLog);
void writeToLogMsg(FILE* fpMsg, const char* logMsg);
FILE* openReportFile();

#endif
