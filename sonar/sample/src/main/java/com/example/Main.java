package com.example;

import java.util.ArrayList;
import java.util.List;

public class SampleApp {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
        buggyMethod();
    }

    // Method with intentional bugs and code smells
    public static void buggyMethod() {
        String unusedVariable = "This is an unused variable";
        List<Integer> list = new ArrayList<>();

        // Intentional infinite loop
        for (int i = 0; i < 10; i--) {
            System.out.println("This is a buggy loop");
        }

        // Adding elements to list and not using it
        for (int i = 0; i < 5; i++) {
            list.add(i);
        }

        // Potential null pointer dereference
        String str = null;
        System.out.println(str.length());

        // Poor naming convention
        int a = 0;
        a++;

        // Unnecessary nested if statement
        if (a > 0) {
            if (a < 10) {
                System.out.println("a is between 1 and 9");
            }
        }
    }
}