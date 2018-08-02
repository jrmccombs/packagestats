#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <ctype.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* The following macros must be defined using -D arguments to the preprocessor:
   LOGDIR=<path to log directory>
*/

/* Function prototypes */

/** \brief Print usage and options.
 * 
 * This function prints the usage line following by a
 * list of command line options and arguments.
 *
 * \param stream a pointer to a FILE instance, usually
 *        stdout or stderr.
 * \param usage a constant character pointer to the
 *        path string indicating the location of the
 *        log file.
 */ 
void print_help(
   FILE *restrict stream,
   const char *restrict usage);

/** \brief Prints the current configuration of this utility.
 *
 * This function prints the path of the log file directory
 * and can be used to print other configuration as necessary.
 *
 * \param logdir a constant character pointer to the path
 *        string indicating the location of the log directory.
 */
void print_configuration(
   const char *restrict logdir);

/** \brief Writes a new log entry by appending it to the log file.
 *
 * This function appends a new log entry to a log file.
 * The log file will be created before appending if it does not
 * already exist and the effective group or user permissions of
 * the exeuctable must match the group or user permissions of the
 * log directory, otherwise an appropriate error message is
 * reported and a return code greater than zero is returned.
 *
 * \param logdir a constant character pointer to the path
 *        string indicating the location of the log file
 *        directory
 * \param logfname a constant character pointer to the name of
 *        the log file
 * \param logentry a constant character pointer to the entry
 *        to be appended to the log file.
 * \return an error code equal to zero if the line was appended
 *        successfully, zero otherwise
 */
int append_log(
   const char *restrict logdir,
   const char *restrict logfname,
   const char *restrict logentry);

/** \brief Prints an error message and a reason for the error.
 *
 * This function prints an error message and a reason description
 * given by an error code for use with the strerror function.
 *
 * \param msg a constant character pointer to an error message to be
 *    printed
 * \param code an integer error code for use with the strerror
 *    function indicating the reason for the error
 */
void print_error_msg_reason(const char *restrict msg, const int code);

/* Static definitions */

/* Executable name */
static const char* exename = NULL;

/* Usage format string */
static const char* usage="USAGE: %s [options]\n\n";

/* Options string */
static const char* options="cf:e:h";

static const char *help[] = {
   "  NOTE: options -f and -e are required when -h or -c are not given",
   "  -h              print this help message, below options ignored",
   "  -c              print configuration information, below options ignored",
   "  -f <log_file>   the name of the log file to write to",
   "  -e <log_entry>  append a log entry to the log file"
};


int
main (int argc, char **argv) {
   int c; /* return value from getopt */
   int cflag = 0;
   int fflag = 0;
   int eflag = 0;
   int hflag = 0;
   int rc = 0;
   const char *logfname = NULL;
   const char *logentry = NULL;
   const char logdir[] = LOGDIR;

   /* Set the executable name */
   exename = strrchr(argv[0], '/');

   /* Get the name of the executable */
   if (exename == NULL) {
      exename = argv[0];
   } else {
     ++exename;
   }

   /* Process the command line options and arguments */
   while ((c = getopt(argc, argv, options)) != -1) {
      switch (c) {
         case 'c':
            cflag = 1;
            break;
         case 'f':
            fflag = 1;
            logfname = optarg;
            break;
         case 'e':
            eflag = 1;
            logentry = optarg;
            break;
         case 'h':
            hflag = 1;
            break;
         case '?':
            if (optopt == 'e') {
               fprintf(stderr, "(%s): Option `-%c' requires an argument.\n",
                  exename, optopt); 
            } else if (isprint(optopt)) {
               fprintf(stderr, "(%s): Unknown option `-%c'.\n",
                  exename, optopt);
            } else {
               fprintf(stderr, "(%s): Unknown option character `\\x%x'.\n",
                  exename, optopt);
            }

            return 1;
         default:
            exit (EXIT_FAILURE);
      }
   }


   /* If help is requested, the help is printed and nothing else */
   /* done.  If the 'f' and 'e' options are given then the log   */
   /* file is appended if the effective group permissions of the */
   /* executable are compatible with those of the log file and   */
   /* log file has group write permissions.                      */

   if (hflag) {
      print_help(stdout, usage);
   } else if (cflag) {
      print_configuration(logdir);
      rc = 1;
   } else if (fflag && eflag) {
      rc = append_log(logdir, logfname, logentry); 
   } else {
      print_help(stderr, usage);
      rc = 1;
   }

   return rc;
}   


void print_help(
   FILE *restrict stream,
   const char *restrict usage) {

   int numlines = sizeof(help)/sizeof(help[0]);

   /* Print the help options lines */
   fprintf(stream, usage, exename);
   fprintf(stream, "OPTIONS:\n");

   for (int i=0; i < numlines; ++i) {
      fprintf(stream, "%s\n", help[i]);
   }
}


void print_configuration(
   const char *restrict logpath) {

   fprintf(stdout, "---%s configuration---\n", exename);
   fprintf(stdout, "%s - '%s'\n", "Path to log directory", logpath);
}


int append_log(
   const char *restrict logdir,
   const char *restrict logfname,
   const char *restrict logentry) {

   int rc = 0;
   int chcount = 0;
   FILE *log = NULL;
   char *logpath = NULL;

   logpath = malloc(sizeof(char)*(strlen(logdir)+strlen(logfname)+2));

   if (logpath == NULL) {
      print_error_msg_reason("Failed to allocate log file path string", errno);
      rc = 1;
   } else {
      strcpy(logpath, logdir);
      strcat(logpath, "/");
      strcat(logpath, logfname);

      log = fopen(logpath, "a");

      /* Check if log file was opened successfully, and append the log */
      /* if it was opened.                                             */
      if (log == NULL) {
         print_error_msg_reason("Failed to open log file for appending", errno);
         rc = 1;
      } else { 
         chcount = fprintf(log, "%s\n", logentry);

         /* Check if the log was written to successfully, and */
         /* print an error message if not.                    */
         if (chcount < 0) {
            rc = 1;
            print_error_msg_reason("Failed to write log entry", errno);
         }

         fclose(log);
      }

      free(logpath);
   }

   return rc;
}


void print_error_msg_reason(const char *restrict msg, const int code) {
   fprintf(stderr, "(%s): error: %s - %s\n", exename, msg, strerror(code));
}
