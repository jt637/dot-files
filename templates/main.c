// cli.cpp
// Copyright
// Written by: Justin Tornetta <your-email@example.com>
// Description: Template for a CLI tool in C++ with subcommands
// Date: YYYY-MM-DD

#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <functional>

void handle_foo(const std::vector<std::string>& args) {
    std::string name = "default";
    int count = 1;

    for (size_t i = 0; i < args.size(); ++i) {
        if (args[i] == "--name" && i + 1 < args.size()) {
            name = args[i + 1];
            ++i;
        } else if (args[i] == "--count" && i + 1 < args.size()) {
            count = std::stoi(args[i + 1]);
            ++i;
        }
    }

    for (int i = 0; i < count; ++i) {
        std::cout << "[foo] Hello, " << name << "!\n";
    }
}

void handle_bar(const std::vector<std::string>& args) {
    bool enable = false;

    for (const auto& arg : args) {
        if (arg == "--enable") {
            enable = true;
        }
    }

    std::cout << "[bar] Feature is " << (enable ? "enabled" : "disabled") << ".\n";
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <subcommand> [options...]\n";
        return 1;
    }

    std::string subcommand = argv[1];
    std::vector<std::string> sub_args(argv + 2, argv + argc);

    std::unordered_map<std::string, std::function<void(const std::vector<std::string>&)>> commands = {
        {"foo", handle_foo},
        {"bar", handle_bar},
    };

    auto it = commands.find(subcommand);
    if (it != commands.end()) {
        it->second(sub_args);
    } else {
        std::cerr << "Unknown subcommand: " << subcommand << "\n";
        return 1;
    }

    return 0;
}