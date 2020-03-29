/* /etc/pam.d/pam_auth */
/*  auth       required     pam_unix.so */
/*  account    required     pam_unix.so */
#include <security/pam_appl.h>
#include <security/pam_misc.h>
#include <stdio.h>

static char* g_passwd;

int check_user_conv(int num_msg, const struct pam_message **msgm,
        struct pam_response **response, void *appdata_ptr)
{
    if (num_msg <= 0)
        return PAM_CONV_ERR;

    struct pam_response *reply;
    reply = (struct pam_response *) calloc(num_msg,
            sizeof(struct pam_response));

    if (reply == NULL) {
        fprintf(stderr, "cannot allocate memory\n");
        return PAM_CONV_ERR;
    }

    for (int count=0; count < num_msg; ++count) {
        /* printf("3 %d/%d, %d, %s\n", count, num_msg */
        /*         , msgm[count]->msg_style */
        /*         , msgm[count]->msg */
        /*         ); */

        char *passwd = g_passwd; //"wsad1234\0";
        char *string = NULL;
        char **retstr;
        retstr = &string;
        *retstr = NULL;
        *retstr = strdup(passwd);

        if (string) {
            reply[count].resp_retcode = 0;
            reply[count].resp = string;
            string = NULL;
        }
    }

    *response = reply;
    reply = NULL;

    return PAM_SUCCESS;

}

static struct pam_conv conv = {
    check_user_conv,
    NULL
};

void clean_exit(){
    g_passwd = NULL;
    exit(1);
}

int main(int argc, char *argv[])
{
    const char *user="nobody";
    if(argc == 3) {
        user = argv[1];
        g_passwd = argv[2];
    }else{
        // TODO: secure usage
        fprintf(stderr, "Usage: check_user [username] [password]\n");
        clean_exit();
    }

    pam_handle_t *pamh=NULL;
    int retval = pam_start("pam_auth", user, &conv, &pamh);

    if (retval == PAM_SUCCESS)
        retval = pam_authenticate(pamh, 0);    /* is user really user? */

    if (retval == PAM_SUCCESS)
        retval = pam_acct_mgmt(pamh, 0);       /* permitted access? */

    /* This is where we have been authorized or not. */

    if (retval == PAM_SUCCESS) {
        fprintf(stdout, "status: success\n");
    } else {
        fprintf(stdout, "status: fail\n");
    }

    if (pam_end(pamh,retval) != PAM_SUCCESS) {     /* close Linux-PAM */
        pamh = NULL;
        fprintf(stderr, "check_user: failed to release authenticator\n");
        clean_exit();
    }

    return ( retval == PAM_SUCCESS ? 0:1 );       /* indicate success */
}
