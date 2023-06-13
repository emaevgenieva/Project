#ifndef _ESQL_FUNCS_H_
#define _ESQL_FUNCS_H_

void sql_error(FILE* fpLog, const char* pszPrefix);
int sql_Connect(FILE* fpMsg, FILE* fpLog, const char* pszConnStri);
void sql_Commit(FILE* fpMsg, FILE* fpLog);
int sql_Select(FILE* fpMsg, FILE* fpLog, const int ID);
int sql_extSelect(FILE* fpMsg, FILE* fpLog, const char* extID);
void sql_UpdateCustomers(FILE* fpMsg, FILE* fpLog, const char* Id, const char* firstName, const char* familyName, const char* sex, 
						 const char* adrCity, const char* adrCountry, const char* creditLimit, const char* email);
void sql_UpdateCustomersExtId(FILE* fpMsg, FILE* fpLog, const char* extId, const char* firstName, const char* familyName, const char* sex, const char* adrCity, 
							  const char* adrCountry, const char* creditLimit, const char* email);
void sql_InsertCustomers(FILE* fpMsg, FILE* fpLog, const char* firstName, const char* familyName, const char* sex, const char* adrCity, 
						 const char* adrCountry, const char* creditLimit, const char* email, const char* extId);
void sql_InsertInvoices(FILE* fpMsg, FILE* fpLog, const char* invNumber, const char* invAmount, const char* invCurremcy, const char* extID);
void sql_InsertPaymens(FILE* fpMsg, FILE* fpLog, const char* payDate, const char* payAmount, const char* payCurremcy, const char* payMethod, const char* extID);
void sql_CommandsAfterCheck(const int rowType);

#endif /* _ESQL_FUNCS_H_ */
