package com.example.app;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class AppTest {
  @Test
  void healthBodyIsOkJson() {
    assertEquals("{\"status\":\"ok\"}", App.healthBody());
  }
}
