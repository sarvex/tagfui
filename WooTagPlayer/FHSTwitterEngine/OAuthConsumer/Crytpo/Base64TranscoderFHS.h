/* Copyright (C) 2014 - present : WooTag Pte - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

#include <stdlib.h>
#include <stdbool.h>

extern size_t EstimateBas64EncodedDataSizeFHS(size_t inDataSize);
extern size_t EstimateBas64DecodedDataSizeFHS(size_t inDataSize);

extern bool Base64EncodeDataFHS(const void *inInputData, size_t inInputDataSize, char *outOutputData, size_t *ioOutputDataSize);
extern bool Base64DecodeDataFHS(const void *inInputData, size_t inInputDataSize, void *ioOutputData, size_t *ioOutputDataSize);

