# langbar

An input-component for controlling your app in natural language using an LLM though LangChain.dart

As you can see, the Creditcard screen is wrapped in a LangbarWrapper, which is responsible for
showing the NLB at the bottom of every screen, but you also omit it on some screens if you prefer.
The actual triggering of routes takes place from LangChain Tools. LangChain Tools are automatically
extracted from the DocumentedGoRoutes and fed into a LangChain agent that generates the prompt.
![Langbar flow](https://raw.githubusercontent.com/hansvdam/langbar/main/docs/img/langbarflow1.png)
