package com.example.integration;

import static org.junit.jupiter.api.Assertions.assertFalse;

import com.example.App;
import org.junit.jupiter.api.Test;

class AppIntegrationTest {
    @Test
    void greetingIsNonEmpty() {
        assertFalse(App.greeting().isBlank());
    }
}
