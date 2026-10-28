#include "app/greet.hpp"

#include <gtest/gtest.h>

TEST(GreetTest, ReturnsExpectedMessage) {
    EXPECT_EQ(app::greeting(), "C++ + CMake");
}
