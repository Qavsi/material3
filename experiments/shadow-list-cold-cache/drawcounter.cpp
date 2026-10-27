#include <atomic>
#include <cstdint>
#include <cstdlib>
#include <dlfcn.h>

static std::atomic<std::uint64_t> calls{0};
extern "C" void study_draw_reset() { calls.store(0, std::memory_order_relaxed); }
extern "C" std::uint64_t study_draw_read() { return calls.load(std::memory_order_relaxed); }
extern "C" void qtDraw(void *, unsigned, unsigned, unsigned, unsigned) asm("__ZN17QRhiCommandBuffer4drawEjjjj");
extern "C" void qtDrawIndexed(void *, unsigned, unsigned, unsigned, int, unsigned) asm("__ZN17QRhiCommandBuffer11drawIndexedEjjjij");
static void countedDraw(void *cb, unsigned a, unsigned b, unsigned c, unsigned d)
{
    calls.fetch_add(1, std::memory_order_relaxed);
    qtDraw(cb, a, b, c, d);
}
static void countedDrawIndexed(void *cb, unsigned a, unsigned b, unsigned c, int d, unsigned e)
{
    calls.fetch_add(1, std::memory_order_relaxed);
    qtDrawIndexed(cb, a, b, c, d, e);
}
#define INTERPOSE(replacement, original) \
    __attribute__((used)) static const struct { const void *replacement; const void *replacee; } entry_##replacement \
    __attribute__((section("__DATA,__interpose"))) = {(const void *)&replacement, (const void *)&original};
INTERPOSE(countedDraw, qtDraw)
INTERPOSE(countedDrawIndexed, qtDrawIndexed)
