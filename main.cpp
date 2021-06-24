#include <iostream>
#include <map>
#include "parser.hpp"
#include <vector>

extern int yylex();
extern std::vector<std::string*> lines;
extern std::string* program;

extern std::map<std::string, std::string> symbols;

int main(int argc, char const *argv[]) {
  if (!yylex()) {
    std::cout << "#include <iostream>" << std::endl;
    std::cout << "int main() {" << std:: endl;

    std::map<std::string, std::string>::iterator it;
    for(it = symbols.begin(); it != symbols.end(); it++)
    {
	    std::cout << "double " << it->first << ';' << std:: endl;
    }

    //std::cout << *lines.at(lines.size() - 2);
    //std::cout << "\t"<< *lines.at(lines.size() - 1);
    std::cout << *program << std::endl;
    

    //Using symbol table to assign all variables.

    // for (it = symbols.begin(); it != symbols.end(); it++) 
    // {
    //   std::cout << it->first << " = " << it->second << ';' << std::endl;
    // }
    
    //Using symbol table to check the variables.
    
    for (it = symbols.begin(); it != symbols.end(); it++)
    {
	    std::cout << "std::cout << \"" + it->first + ": \" " + "<< " + it->first + "<< std::endl;" << std::endl;
    }

    std::cout << "return 0;" << std::endl;
    std::cout << '}' << std::endl;
    return 0;
  } else {
    return 1;
  }
}