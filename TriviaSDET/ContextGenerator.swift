import Foundation

func generateContext(for topic: String) -> String {
    let contexts: [String: String] = [
        "Java": """
            Focus on core Java concepts, OOP principles, and practical implementations. 
            Provide examples and explain the underlying concepts clearly.
            """,
        
        "Selenium": """
            Explain automation concepts, best practices, and real-world scenarios. 
            Include examples of how you've handled common challenges.
            """,
        
        "SQL": """
            Focus on database concepts, query optimization, and practical examples. 
            Explain your approach to solving database challenges.
            """,
        
        "Git": """
            Explain version control concepts, branching strategies, and common workflows. 
            Include examples of how you use these in your daily work.
            """,
        
        "API": """
            Focus on REST principles, request/response handling, and testing strategies. 
            Include examples of tools and frameworks you've used.
            """,
        
        "CI/CD": """
            Explain continuous integration/deployment concepts, pipeline creation, 
            and automation strategies. Include real-world implementation examples.
            """
    ]
    
    return contexts[topic] ?? """
        Provide a comprehensive answer with examples from your experience. 
        Focus on practical implementations and best practices.
        """
}
