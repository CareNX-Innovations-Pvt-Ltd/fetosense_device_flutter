#include <cstdint>
#include <algorithm>
#include <vector>

class ADPCM {
private:
    // ADPCM step size table
    static const int16_t stepSizeTable[89];

    // ADPCM index table
    static const int8_t indexTable[16];

public:
    /**
     * Decodes ADPCM data.
     *
     * @param out Output buffer for decoded data
     * @param outOffset Offset in output buffer
     * @param in Input buffer with ADPCM data
     * @param inOffset Offset in input buffer
     * @param len Length of data to decode
     * @param predsample Previous sample value
     * @param index Step size index
     * @param flag Flags for decoding
     */
    #include <algorithm>
#include <stdint.h>

static void decodeAdpcm(int16_t* out, int outOffset, const uint8_t* in, int inOffset,
                        int len, int16_t predSample, uint8_t index, uint8_t flag) {
    int step, idx;

    idx = index;

    for (int i = 0; i < len; i++) {
        uint8_t inputByte = in[i + inOffset];

        for (int j = 0; j < 2; j++) {
            uint8_t code = (j == 0) ? ((inputByte >> 0) & 0x0F) : ((inputByte >> 4) & 0x0F);

            step = stepSizeTable[idx];

            // Inverse quantize the ADPCM code
            int diff = (step >> 3);
            if ((code & 4) != 0) diff += step;
            if ((code & 2) != 0) diff += step >> 1;
            if ((code & 1) != 0) diff += step >> 2;

            // Add or subtract from the predicted sample
            if (code & 8) {
                predSample -= diff;
            } else {
                predSample += diff;
            }

            // Clamp predicted sample to 16-bit range
            predSample = std::max<int16_t>(-32768, std::min<int16_t>(32767, predSample));

            // Update step size index
            idx = std::max(0, std::min(88, idx + indexTable[code]));
            out[outOffset++] = predSample;
        }
    }
}


    
    /* static void decodeAdpcm(int16_t* out, int outOffset, const uint8_t* in, int inOffset,
                                int len, int16_t predsample, uint8_t index, uint8_t flag) {
        int step, predSample, idx;

        idx = index;
        predSample = predsample;
        int sign,delta;
        int adpcm_index;
        int adpcm_value;

        short dat = 0;
        int vpdiff;
        adpcm_value = (in[3] << 8) + in[4];
        adpcm_index = in[5];


        for(int i=0;i<100;i++) //There are 100 bytes of sound in each packet, 200 after decompression
        {

            uint8_t inputByte = in[i + inOffset]; // get next data
            for(int j=0;j<2;j++) //Convert the upper 4 bits and lower 4 bits of one byte of com.luckcome.data into two bytes of com.luckcome.data, respectively
            {
                step = stepSizeTable[idx];
                if(j==0)
                    delta = (inputByte >> 0) & 0xf;
                else
                    delta = (inputByte >> 4) & 0xf;

                sign = delta & 8;

                vpdiff = step >> 3;
                if ( (delta & 4) != 0 ) vpdiff += step;
                if ( (delta & 2) != 0 ) vpdiff += step>>1;
                if ( (delta & 1) != 0 ) vpdiff += step>>2;

                if (sign)
                {
                    adpcm_value -= vpdiff;
                    if ( adpcm_value < -32768 )
                        adpcm_value = -32768;
                }
                else
                {
                    adpcm_value += vpdiff;
                    if ( adpcm_value > 32767 )
                        adpcm_value = 32767;
                }
                step = stepSizeTable[adpcm_index];

                adpcm_index += indexTable[delta];
                if (adpcm_index<0) adpcm_index=0;
                if (adpcm_index>88) adpcm_index=88;

                dat = (short)(adpcm_value*1) ;


                if(dat > 0xfff)
                    dat = 0xfff;
                if(dat < 0)
                    dat = 0;


                dat = (short)((dat - 0X800)/1 + 0x80);

                if (dat > 0xff) {
                    dat = 0xff;
                }
                if (dat < 0) {
                    dat = 0;
                }

                out[outOffset++] = dat;
            }
        }
    } */

    /**
     * Decodes ADPCM data for 10 or 12-bit samples with 100ms frame size.
     *
     * @param out Output buffer for decoded data
     * @param outOffset Offset in output buffer
     * @param in Input buffer with ADPCM data
     * @param inOffset Offset in input buffer
     * @param len Length of data to decode
     * @param predsample Previous sample value
     * @param index Step size index
     * @param flag Flags for decoding
     * @param bitWidth Bit width (10 or 12)
     */
    static void decodeAdpcmFor10Or12BitAnd100ms(int16_t* out, int outOffset, const uint8_t* in,
                                                int inOffset, int len, int16_t predsample,
                                                uint8_t index, uint8_t flag, uint8_t bitWidth) {
        int step, predSample, idx;

        idx = index;
        predSample = predsample;

        uint16_t mask = 0;
        uint8_t shift = 0;

        if (bitWidth == 10) {
            mask = 0x3FF;  // 10 bits
            shift = 10;
        } else if (bitWidth == 12) {
            mask = 0xFFF;  // 12 bits
            shift = 12;
        }

        for (int i = 0; i < len; i++) {
            uint16_t value = 0;
            // Combine multiple bytes for wider bit widths
            if (bitWidth == 10) {
                // For 10-bit, combine parts of multiple bytes
                int byteIndex = (i * 10) / 8 + inOffset;
                int bitOffset = (i * 10) % 8;

                // Read across byte boundaries if needed
                uint16_t firstByte = in[byteIndex];
                uint16_t secondByte = (byteIndex + 1 < len + inOffset) ? in[byteIndex + 1] : 0;

                value = ((firstByte << 8) | secondByte) >> (16 - 10 - bitOffset);
                value &= mask;
            } else if (bitWidth == 12) {
                // For 12-bit, combine parts of multiple bytes
                int byteIndex = (i * 12) / 8 + inOffset;
                int bitOffset = (i * 12) % 8;

                // Read across byte boundaries if needed
                uint32_t firstByte = in[byteIndex];
                uint32_t secondByte = (byteIndex + 1 < len + inOffset) ? in[byteIndex + 1] : 0;
                uint32_t thirdByte = (byteIndex + 2 < len + inOffset) ? in[byteIndex + 2] : 0;

                value = ((firstByte << 16) | (secondByte << 8) | thirdByte) >> (24 - 12 - bitOffset);
                value &= mask;
            }

            // Process the sample similarly to regular ADPCM
            uint8_t code = value & 0x0F; // Use lower 4 bits for code

            step = stepSizeTable[idx];

            // Inverse quantize
            int diff = (step >> 3);
            if (code & 0x4) diff += step;
            if (code & 0x2) diff += (step >> 1);
            if (code & 0x1) diff += (step >> 2);

            // Add or subtract
            if (code & 0x8) {
                predSample -= diff;
            } else {
                predSample += diff;
            }

            // Clamp
            predSample = std::max<int16_t>(-32768, std::min<int16_t>(32767, predSample));

            // Update index
            idx = std::max(0, std::min(88, idx + indexTable[code]));

            // Store result
            out[outOffset++] = predSample;
        }
    }
};

// Define the static tables
const int16_t ADPCM::stepSizeTable[89] = {
        7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
        50, 55, 60, 66, 73, 80, 88, 97, 107, 118, 130, 143, 157, 173, 190, 209, 230,
        253, 279, 307, 337, 371, 408, 449, 494, 544, 598, 658, 724, 796, 876, 963,
        1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066, 2272, 2499, 2749, 3024, 3327,
        3660, 4026, 4428, 4871, 5358, 5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487,
        12635, 13899, 15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
};

const int8_t ADPCM::indexTable[16] = {
        -1, -1, -1, -1, 2, 4, 6, 8,
        -1, -1, -1, -1, 2, 4, 6, 8
};

// FFI Wrapper functions
extern "C" {
    void decode_adpcm(int16_t* out, int outOffset, const uint8_t* in, int inOffset,
                    int len, int16_t predsample, uint8_t index, uint8_t flag) {
        ADPCM::decodeAdpcm(out, outOffset, in, inOffset, len, predsample, index, flag);
    }

    void decode_adpcm_for_10_or_12_bit_and_100ms(int16_t* out, int outOffset, const uint8_t* in,
                                                int inOffset, int len, int16_t predsample,
                                                uint8_t index, uint8_t flag, uint8_t bitWidth) {
        ADPCM::decodeAdpcmFor10Or12BitAnd100ms(out, outOffset, in, inOffset, len, predsample, index, flag, bitWidth);
    }
}