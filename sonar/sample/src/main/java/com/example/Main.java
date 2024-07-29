package com.example;

public class SampleCode {

    private int defaultVal = 0;

    public static void main(String[] args) {
        SampleCode sc = new SampleCode();
        sc.processData(null);
        sc.divide(10, 0);
        String result = sc.generateMessage("John", null);
        System.out.println(result);
    }

    public void logMessage(String message) {
        System.out.println("LOG: " + message); // Potential security issue: Logging without proper encoding
    }

    public void processData(String data) {
        if (data.length() > 10) { // NullPointerException potential
            System.out.println("Data is too long");
        } else {
            System.out.println("Data is fine");
        }
    }

    public int divide(int a, int b) {
        return a / b; // ArithmeticException for division by zero
    }

    public String generateMessage(String first, String second) {
        return first + " " + second;
    }
}