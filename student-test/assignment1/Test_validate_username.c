#include "unity.h"
#include <stdbool.h>
#include <stdlib.h>
#include "../../examples/autotest-validate/autotest-validate.h"
#include "../../assignment-autotest/test/assignment1/username-from-conf-file.h"

/**
* This function should:
*   1) Call the my_username() function in Test_assignment_validate.c to get your hard coded username.
*   2) Obtain the value returned from function malloc_username_from_conf_file() in username-from-conf-file.h within
*       the assignment autotest submodule at assignment-autotest/test/assignment1/
*   3) Use unity assertion TEST_ASSERT_EQUAL_STRING_MESSAGE the two strings are equal.  See
*       the [unity assertion reference](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityAssertionsReference.md)
*/


void test_validate_my_username()
{
		char* empty_string = "=================================";
		puts(empty_string);
		puts(empty_string);
		puts(empty_string);
		
		char my_name[] = "NC6000";
		puts(my_name);
		
		//STEP 1 CALL FUNCTION my_username()
		
		char my_hardcoded_name = *my_username();
		printf("My name is %c\n", my_hardcoded_name);
		char* my_hardcoded_name_string = (char*)my_username(sizeof(char)*5);
		char* my_hardcoded_name_string1 = (char*)my_username(sizeof(char)*10);
		char* my_hardcoded_name_string2 = (char*)my_username();
		printf("%s\n", my_hardcoded_name_string);
		printf("%s\n", my_hardcoded_name_string1);
		printf("%s\n", my_hardcoded_name_string2);
		puts(my_hardcoded_name_string);
		puts(my_hardcoded_name_string1);
		puts(my_hardcoded_name_string2);
	 	puts(empty_string);
		
		

		puts(empty_string);
		
		//STEP 2 CALL FUNCTION malloc_username_from_conf_file()
		
		
		
		char* my_name_from_config_string = (char*)malloc_username_from_conf_file();
		puts(empty_string);
		printf("%s\n", my_name_from_config_string);
		puts(my_name_from_config_string);
		
		puts(empty_string);




    /**
     * TODO: Replace the line below with your code here as described above to verify your /conf/username.txt 
     * config file and my_username() functions are setup properly
     */
     
    //TEST_ASSERT_TRUE_MESSAGE(false,"AESD students, please fix me!");
    TEST_ASSERT_EQUAL_STRING_MESSAGE(my_hardcoded_name_string, my_name_from_config_string, "Username is not configured correctly!");
    
    
}
