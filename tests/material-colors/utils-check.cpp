// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

#include "cpp/utils/utils.h"
#include <iostream>
#include <utility>

int main()
{
    const std::pair<material_color_utilities::Argb, const char *> cases[] = {
        {0, "0"}, {0x00000123, "123"}, {0xff012345, "ff012345"}, {0xffffffff, "ffffffff"}
    };
    int failures = 0;
    for (const auto &[argb, expected] : cases) {
        const auto actual = material_color_utilities::HexFromArgb(argb);
        if (actual != expected) {
            std::cerr << "FAIL: HexFromArgb expected " << expected << " actual " << actual << '\n';
            ++failures;
        }
    }
    std::cout << "MCU hex conversion: assertions 4 failures " << failures << '\n';
    return failures ? 1 : 0;
}
