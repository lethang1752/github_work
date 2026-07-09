create or replace NONEDITIONABLE FUNCTION     dba_password_verify_function
(username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS
   n boolean;
   m integer;
   differ integer;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(26);
   upperchararray varchar2(26);

BEGIN
   digitarray:= '0123456789';
   chararray:= 'abcdefghijklmnopqrstuvwxyz';
   upperchararray:= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray:='!"#$%&()``*+,-/:;<=>?_';

   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password same as or similar to user.');
   END IF;

   -- Check for the minimum length of the password
   IF length(password) < 16 THEN
      raise_application_error(-20002, 'Password length less than 16.');
   END IF;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 'password', 'oracle', 'computer', 'abc', 'def','abc@123','tf@1234','ln@1234','gl@1234','ga@1234','dl@1234','cs@1234','dh@1234','abc@123') THEN
      raise_application_error(-20002, 'Password too simple');
   END IF;

   -- Check if the password contains at least one letter, one digit and one
   -- punctuation mark.
   -- 1. Check for the digit
   isdigit:=FALSE;
   m := length(password);
   FOR i IN 1..10 LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
            isdigit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation.');
      --raise_application_error(-20003, 'Password nen chua it nhat mot ki tu so, mot ki tu character, mot ki tu dac biet(khong nen dat ky tu @)');

   END IF;
   -- 2. Check for the character
   <<findchar>>
   ischar:=FALSE;
   FOR i IN 1..length(chararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(chararray,i,1) THEN
            ischar:=TRUE;
             GOTO findupper;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one character.');
              --raise_application_error(-20003, 'Password should contain at least one \
              --digit, one character and one punctuation');

   END IF;

   -- 3. Check for the character
   <<findupper>>
   ischar:=FALSE;
   FOR i IN 1..length(upperchararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(upperchararray,i,1) THEN
            ischar:=TRUE;
             GOTO findpunct;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one upper character.');
              --raise_application_error(-20003, 'Password should contain at least one \
              --digit, one character and one punctuation');

   END IF;
   -- 4. Check for the punctuation
   <<findpunct>>
   ispunct:=FALSE;
   FOR i IN 1..length(punctarray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
            ispunct:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
              --raise_application_error(-20003, 'Password nen chua it nhat mot \
              --so, mot ky tu char va mot ky tu dac biet(khuyen cao ko nen dat @)');
   END IF;

   <<endsearch>>
   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := length(old_password) - length(password);

     IF abs(differ) < 3 THEN
       IF length(password) < length(old_password) THEN
         m := length(password);
       ELSE
         m := length(old_password);
       END IF;

       differ := abs(differ);
       FOR i IN 1..m LOOP
         IF substr(password,i,1) != substr(old_password,i,1) THEN
           differ := differ + 1;
         END IF;
       END LOOP;

       IF differ < 3 THEN
         raise_application_error(-20004, 'Password should differ by at least 3 characters');
       END IF;
     END IF;
   END IF;
   -- Everything is fine; return TRUE ;
   RETURN(TRUE);
END;
/

create or replace NONEDITIONABLE FUNCTION     DEV_password_verify_function
(username varchar2,
  password varchar2,
  old_password varchar2)
  RETURN boolean IS
   n boolean;
   m integer;
   differ integer;
   isdigit boolean;
   ischar  boolean;
   ispunct boolean;
   digitarray varchar2(20);
   punctarray varchar2(25);
   chararray varchar2(26);
   upperchararray varchar2(26);

BEGIN
   digitarray:= '0123456789';
   chararray:= 'abcdefghijklmnopqrstuvwxyz';
   upperchararray:= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   punctarray:='!"#$%&()``*+,-/:;<=>?_';

   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password same as or similar to user.');
   END IF;

   -- Check for the minimum length of the password
   IF length(password) < 9 THEN
      raise_application_error(-20002, 'Password length less than 16.');
   END IF;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 'password', 'oracle', 'computer', 'abc', 'def','abc@123','tf@1234','ln@1234','gl@1234','ga@1234','dl@1234','cs@1234','dh@1234','abc@123') THEN
      raise_application_error(-20002, 'Password too simple');
   END IF;

   -- Check if the password contains at least one letter, one digit and one
   -- punctuation mark.
   -- 1. Check for the digit
   isdigit:=FALSE;
   m := length(password);
   FOR i IN 1..10 LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(digitarray,i,1) THEN
            isdigit:=TRUE;
             GOTO findchar;
         END IF;
      END LOOP;
   END LOOP;
   IF isdigit = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation.');
      --raise_application_error(-20003, 'Password nen chua it nhat mot ki tu so, mot ki tu character, mot ki tu dac biet(khong nen dat ky tu @)');

   END IF;
   -- 2. Check for the character
   <<findchar>>
   ischar:=FALSE;
   FOR i IN 1..length(chararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(chararray,i,1) THEN
            ischar:=TRUE;
             GOTO findupper;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one character.');
              --raise_application_error(-20003, 'Password should contain at least one \
              --digit, one character and one punctuation');

   END IF;

   -- 3. Check for the character
   <<findupper>>
   ischar:=FALSE;
   FOR i IN 1..length(upperchararray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(upperchararray,i,1) THEN
            ischar:=TRUE;
             GOTO findpunct;
         END IF;
      END LOOP;
   END LOOP;
   IF ischar = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one upper character.');
              --raise_application_error(-20003, 'Password should contain at least one \
              --digit, one character and one punctuation');

   END IF;
   -- 4. Check for the punctuation
   <<findpunct>>
   ispunct:=FALSE;
   FOR i IN 1..length(punctarray) LOOP
      FOR j IN 1..m LOOP
         IF substr(password,j,1) = substr(punctarray,i,1) THEN
            ispunct:=TRUE;
             GOTO endsearch;
         END IF;
      END LOOP;
   END LOOP;
   IF ispunct = FALSE THEN
      raise_application_error(-20003, 'Password should contain at least one digit, one character and one punctuation');
              --raise_application_error(-20003, 'Password nen chua it nhat mot \
              --so, mot ky tu char va mot ky tu dac biet(khuyen cao ko nen dat @)');
   END IF;

   <<endsearch>>
   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := length(old_password) - length(password);

     IF abs(differ) < 3 THEN
       IF length(password) < length(old_password) THEN
         m := length(password);
       ELSE
         m := length(old_password);
       END IF;

       differ := abs(differ);
       FOR i IN 1..m LOOP
         IF substr(password,i,1) != substr(old_password,i,1) THEN
           differ := differ + 1;
         END IF;
       END LOOP;

       IF differ < 3 THEN
         raise_application_error(-20004, 'Password should differ by at least 3 characters');
       END IF;
     END IF;
   END IF;
   -- Everything is fine; return TRUE ;
   RETURN(TRUE);
END;
/
