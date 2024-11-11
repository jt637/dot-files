// Copyright
// Written by: Justin Tornetta ()
// Description:
// Date:

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

void print_usage(const char *prog_name) {
    printf("Usage: %s <command> [options]\n", prog_name);
    printf("Commands:\n");
    printf("  generate-key                Generate RSA key\n");
    printf("  encrypt                     Encrypt a file\n");
    printf("  decrypt                     Decrypt a file\n");
    printf("Options:\n");
    printf("  -s, --src <file>     Input file for encryption/decryption\n");
    printf("  -d, --dst <file>    Output file for encryption/decryption\n");
    printf("  -k, --key-id <id>           RSA key ID for encryption/decryption\n");
    printf("  -h, --help                  Show this help message\n");
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        print_usage(argv[0]);
        return 1;
    }

    // Command handler
    if (strcmp(argv[1], "generate-key") == 0) {
        // Handle RSA key generation
        const char *public_key_file = "public_key.pem";
        if (yubihsm_generate_rsa_key(&rsa_key_id, public_key_file) != 0) {
            fprintf(stderr, "Failed to generate RSA key\n");
            return 1;
        }
        printf("RSA key generated with ID: %04x\n", rsa_key_id);
        printf("Public key saved to: %s\n", public_key_file);
    }
    else if (strcmp(argv[1], "encrypt") == 0) {
        // Handle file encryption
        static struct option long_options[] = {
            {"src", required_argument, NULL, 's'},
            {"dst", required_argument, NULL, 'd'},
            {"key-id", required_argument, NULL, 'k'},
            {"help", no_argument, NULL, 'h'},
            {0, 0, 0, 0}
        };
        
        int opt;
        while ((opt = getopt_long(argc, argv, "i:o:k:h", long_options, NULL)) != -1) {
            switch (opt) {
                case 's':
                    input_file = optarg;
                    break;
                case 'd':
                    output_file = optarg;
                    break;
                case 'k':
                    rsa_key_id = (uint16_t)strtol(optarg, NULL, 0); // Parse key ID as hex or decimal
                    break;
                case 'h':
                    print_usage(argv[0]);
                    return 0;
                default:
                    print_usage(argv[0]);
                    return 1;
            }
        }
        
        if (!input_file || !output_file || rsa_key_id == 0) {
            fprintf(stderr, "Input file, output file, and key ID must be specified for encryption.\n");
            return 1;
        }
        
        if (encrypt_rsa(rsa_key_id, input_file, output_file) != 0) {
            fprintf(stderr, "Failed to encrypt the file.\n");
            return 1;
        }
        printf("File encrypted successfully. Output saved to: %s\n", output_file);
    }
    else if (strcmp(argv[1], "decrypt") == 0) {
        // Handle file decryption
        static struct option long_options[] = {
            {"src", required_argument, NULL, 's'},
            {"dst", required_argument, NULL, 'd'},
            {"key-id", required_argument, NULL, 'k'},
            {"help", no_argument, NULL, 'h'},
            {0, 0, 0, 0}
        };

        int opt;
        while ((opt = getopt_long(argc, argv, "i:o:k:h", long_options, NULL)) != -1) {
            switch (opt) {
                case 's':
                    input_file = optarg;
                    break;
                case 'd':
                    output_file = optarg;
                    break;
                case 'k':
                    rsa_key_id = (uint16_t)strtol(optarg, NULL, 0); // Parse key ID as hex or decimal
                    break;
                case 'h':
                    print_usage(argv[0]);
                    return 0;
                default:
                    print_usage(argv[0]);
                    return 1;
            }
        }
    }
    else {
        // Invalid command
        print_usage(argv[0]);
        return 1;
    }

    return 0;
}