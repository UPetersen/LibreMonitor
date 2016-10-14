// LICENSES: [077915]
// -----------------------------------
// The contents of this file contains the aggregate of contributions
//   covered under one or more licences. The full text of those licenses
//   can be found in the "LICENSES" file at the top level of this project
//   identified by the MD5 fingerprints listed above.
//
// Uwe Petersen: Modified version to test transmission part in iOS



#import <Foundation/Foundation.h>

typedef uint8_t byte;


byte CRC8(void *data_in, byte number_of_bytes_to_read);
