package com.example.app;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

/** Minimal JDK HTTP server — no Spring. */
public final class App {
  private App() {}

  public static void main(String[] args) throws IOException {
    int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
    HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
    server.createContext("/health", App::handleHealth);
    server.start();
    System.out.println("listening on :" + port);
  }

  static String healthBody() {
    return "{\"status\":\"ok\"}";
  }

  static void handleHealth(HttpExchange exchange) throws IOException {
    byte[] body = healthBody().getBytes(StandardCharsets.UTF_8);
    exchange.sendResponseHeaders(200, body.length);
    try (OutputStream os = exchange.getResponseBody()) {
      os.write(body);
    }
  }
}
