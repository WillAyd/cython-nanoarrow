from libc.stdlib cimport malloc
from libc.stdint cimport (
    int8_t,    
    int64_t,
    uint8_t,
)
from libc.string cimport memset

cdef extern from "nanoarrow.h":
    struct ArrowBuffer:
        uint8_t* data
        int64_t size_bytes

    struct ArrowBitmap:
        ArrowBuffer buffer
        int64_t size_bits

    void ArrowBitmapInit(ArrowBitmap*)
    void ArrowBitmapReserve(ArrowBitmap*, int64_t)
    void ArrowBitsSetTo(uint8_t*, int64_t, int64_t, uint8_t)
    void ArrowBitsUnpackInt8(const uint8_t*, int64_t, int64_t, int8_t*)
    void ArrowBitsUnpackInt8NoShift(const uint8_t*, int64_t, int64_t, int8_t*)
    void ArrowBitsUnpackInt8Multiply(const uint8_t*, int64_t, int64_t, int8_t*)
    void ArrowBitmapAppendInt8Unsafe(ArrowBitmap*, const int8_t*, int64_t)
    void ArrowBitmapAppendInt8UnsafeNoShift(ArrowBitmap*, const int8_t*, int64_t)
    void ArrowBitmapAppendInt8UnsafeMultiply(ArrowBitmap*, const int8_t*, int64_t)    
    void ArrowBitmapReset(ArrowBitmap*)

cdef class ComparisonManager:
    cdef:
        ArrowBitmap bitmap
        uint8_t* buf
        int64_t N

    def __cinit__(self):
        cdef ArrowBitmap bitmap
        cdef int64_t N = 1_000_000
        cdef uint8_t* buf

        ArrowBitmapInit(&bitmap)
        ArrowBitmapReserve(&bitmap, N)
        ArrowBitsSetTo(bitmap.buffer.data, 0, N, 1)
        self.bitmap = bitmap
        self.buf = <uint8_t*>malloc(N)
        self.N = N

    def __dealloc__(self):
        cdef ComparisonManager self_ = self        
        ArrowBitmapReset(&self_.bitmap)

    def unpack(self):
        cdef ComparisonManager self_ = self
        ArrowBitsUnpackInt8(self_.bitmap.buffer.data, 0, self_.N, <int8_t*>self_.buf)

    def unpack_no_shift(self):
        cdef ComparisonManager self_ = self        
        ArrowBitsUnpackInt8NoShift(self_.bitmap.buffer.data, 0, self_.N, <int8_t*>self_.buf)

    def unpack_multiply(self):
        cdef ComparisonManager self_ = self        
        ArrowBitsUnpackInt8Multiply(self_.bitmap.buffer.data, 0, self_.N, <int8_t*>self_.buf)        

    def pack(self):
        cdef ComparisonManager self_ = self
        memset(self_.buf, 0, self_.N)
        self_.bitmap.size_bits = 0  # hack to avoid append overruning buffer
        ArrowBitmapAppendInt8Unsafe(&(self_.bitmap), <const int8_t*>self_.buf, self_.N)

    def pack_no_shift(self):
        cdef ComparisonManager self_ = self
        memset(self_.buf, 0, self_.N)
        self_.bitmap.size_bits = 0  # hack to avoid append overruning buffer
        ArrowBitmapAppendInt8UnsafeNoShift(&(self_.bitmap), <const int8_t*>self_.buf, self_.N)

    def pack_multiply(self):
        cdef ComparisonManager self_ = self
        memset(self_.buf, 0, self_.N)
        self_.bitmap.size_bits = 0  # hack to avoid append overruning buffer
        ArrowBitmapAppendInt8UnsafeMultiply(&(self_.bitmap), <const int8_t*>self_.buf, self_.N)                
