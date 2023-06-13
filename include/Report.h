#ifndef REPORT_H
#define REPORT_H

void sql_clientInvoices(FILE* fpMsg, FILE* fpLog, int vCustomerID, FILE* fp);
void sql_periodInvoices(FILE* fpMsg, FILE* fpLog, char* dateFrom, char* dateTo, FILE* fp);
//void stringTrim(char* str);
//void extract_customers_with_no_payments(char* date_from, char* date_to);

#endif
