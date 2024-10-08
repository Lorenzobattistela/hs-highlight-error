
module Main where

import Test.Hspec
import Highlight

main :: IO ()
main = hspec $ do
  describe "Highlight" $ do
    describe "getColor" $ do
      it "returns correct ANSI color code for known colors" $ do
        getColor "red" `shouldBe` "\x1b[31m"
        getColor "green" `shouldBe` "\x1b[32m"
        getColor "yellow" `shouldBe` "\x1b[33m"
        getColor "blue" `shouldBe` "\x1b[34m"
        getColor "cyan" `shouldBe` "\x1b[36m"
      
      it "returns reset for unknown colors" $ do
        getColor "unknown" `shouldBe` "\x1b[0m"

    describe "highlight" $ do
      it "highlights a single line correctly" $ do
        let text = "This is a test"
            result = highlight (1, 1) (1, 4) (getColor "red") id text
        result `shouldContain` "\ESC[31mThi\ESC[0ms"

      it "highlights multiple lines correctly" $ do
        let text = "First line\nSecond line\nThird line"
            result = highlight (1, 1) (2, 3) (getColor "blue") id text
        result `shouldContain` "\ESC[34mFirst line\ESC[0m\n2 | \ESC[34mSe\ESC[0mcond line\n"

    describe "file bound check" $ do
      it "does not highlight if line does not exist" $ do
        let text = "hello"
            result = highlight (2, 1) (2, 10) (getColor "red") id text
        result `shouldBe` ""

      it "does not highlight a line past end of the file" $ do
        let text = "hello"
            result = highlight (1, 1) (2, 10) (getColor "red") id text
        result `shouldBe` "1 | \ESC[31mhello\ESC[0m\n"

      it "does not highlight a column that does not exist" $ do
        let text = "hello"
            result = highlight (1, 30) (1, 50) (getColor "red") id text
        result `shouldBe` "1 | hello\n"

      it "does not highlight a column past end of the file" $ do
        let text = "hello"
            result = highlight (1, 1) (1, 50) (getColor "red") id text
        result `shouldBe` "1 | \ESC[31mhello\ESC[0m\n"



    describe "highlightError" $ do
      it "highlights an error in a single line" $ do
        let text = "This is a test with an error"
            result = highlightError (1, 11) (1, 15) text
        result `shouldContain` "\ESC[31m\ESC[4mtest\ESC[24m\ESC[0m"

      it "highlights an error across multiple lines" $ do
        let text = "First line\nSecond line with error\nThird line"
            result = highlightError (2, 8) (3, 6) text
        result `shouldContain` "Second \ESC[31m\ESC[4mline with error\ESC[24m\ESC[0m\n3 | \ESC[31m\ESC[4mThird\ESC[24m\ESC[0m line\n"

    describe "Integration test" $ do
      it "correctly highlights a complex multi-line text with UTF-8 characters" $ do
        let text = "function greet(name) {\n  console.log(\"Hello, \" + name + \"!\");\n  return \"Greeted \" + name;\n}\n\ngreet(\"世界\");"
            result = highlightError (2, 15) (2, 32) text
        result `shouldContain` "2 |   console.log(\ESC[31m\ESC[4m\"Hello, \" + name \ESC[24m\ESC[0m+ \"!\");\n"
        result `shouldNotContain` "\x1b[31m\ESC[4mfunction\x1b[0m"
        result `shouldNotContain` "\x1b[31m\ESC[4m世界\x1b[0m"


