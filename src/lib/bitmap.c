#include <cnix/bitmap.h>
#include <cnix/string.h>
#include <cnix/cnix.h>
#include <cnix/assert.h>

void bitmap_make(bitmap_t *map, char *bits, u32 length, u32 offset)
{
    map->bits = bits;
    map->length = length;
    map->offset = offset;
}

void bitmap_init(bitmap_t *map, char *bits, u32 length, u32 start)
{
    memset(bits, 0, length);
    bitmap_make(map, bits, length, start);
}

bool bitmap_test(bitmap_t *map, idx_t index)
{
    assert(index >= map->offset);

    idx_t idx = index - map->offset;

    u32 bytes = idx / 8;

    u8 bits = idx % 8;

    assert(bytes < map->length);

    return (map->bits[bytes] & (1 << bits));
}

void bitmap_set(bitmap_t *map, idx_t index, bool value)
{
    assert(value == 0 || value == 1);

    assert(index >= map->offset);

    idx_t idx = index - map->offset;

    u32 bytes = idx / 8;

    u8 bits = idx % 8;
    if (value)
    {
        map->bits[bytes] |= (1 << bits);
    }
    else
    {
        map->bits[bytes] &= -(1 << bits);
    }
}

int bitmap_scan(bitmap_t *map, u32 count)
{
    int start = EOF;
    u32 bits_left = map->length * 8;
    u32 next_bit = 0;
    u32 counter = 0;

    while (bits_left-- > 0)
    {
        if (!bitmap_test(map, map->offset + next_bit))
        {
            counter++;
        }
        else
        {
            counter = 0;
        }

        next_bit++;

        if (counter == count)
        {
            start = next_bit - count;
            break;
        }
    }

    if (start == EOF)
        return EOF;

    bits_left = count;
    next_bit = start;
    while (bits_left--)
    {
        bitmap_set(map, map->offset + next_bit, true);
        next_bit++;
    }

    return start + map->offset;
}

/* #include <cnix/debug.h> */
/**/
/* #define LOGK(fmt, args...) DEBUGK(fmt, ##args) */
/**/
/* #define LEN 2 */
/* u8 buf[LEN]; */
/* bitmap_t map; */
/**/
/* void bitmap_tests() */
/* { */
/*     bitmap_init(&map, buf, LEN, 0); */
/*     for (size_t i = 0; i < 33; i++) */
/*     { */
/*         idx_t idx = bitmap_scan(&map, 1); */
/*         if (idx == EOF) */
/*         { */
/*             LOGK("TEST FINISH\n"); */
/*             break; */
/*         } */
/*         LOGK("%d\n", idx); */
/*     } */
/* } */
