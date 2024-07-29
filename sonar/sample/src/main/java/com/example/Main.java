package com.example;

import java.util.ArrayList;
import java.util.List;

public class Main {

    public static void main(String[] args) {
        System.out.println("Hello, World!");

        List<String> list = null; // Null pointer risk
        list.add("This will cause a NullPointerException"); // This will fail

        String foo = "bar"; // Unused variable
        int magicNumber = 42; // Magic number

        for (int i = 0; i < 10; i++) {
            // Do nothing loop
        }

        if (magicNumber == 42) {
            System.out.println("Magic number found");
        } else if (magicNumber == 43) {
            System.out.println("Another number found");
        } else {
            System.out.println("Default case");
        }
    }

    // Method with poor naming convention and unused parameter
    public void doSomething(int x, String y) {
        // Empty method body
    }
}