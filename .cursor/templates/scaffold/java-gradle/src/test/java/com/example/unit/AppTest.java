package com.example.unit;

import static org.junit.jupiter.api.Assertions.assertEquals;

import com.example.App;
import org.junit.jupiter.api.Test;

class AppTest {
    @Test
    void greetingReturnsHello() {
        assertEquals("Hello", App.greeting());
    }
}
