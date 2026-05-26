import asyncio
from mcp import  ClientSession , StdioServerParameters
from mcp.client.stdio import stdio_client

server_parameters = StdioServerParameters(
    command="coral",
    args=["mcp-stdio"],
)



async def main():
    async with stdio_client(server_parameters) as (read, write):
        async with ClientSession(read,write) as session:
            await session.initialize()

            # tool call
            tool = await  session.list_tools()
            # list catalog
            result = await session.call_tool("list_catalog",{})
            print(result)

            #query call
            query = await session.call_tool("sql",{"sql":"SELECT * FROM coral.tables LIMIT 5"})
            print(query)

asyncio.run(main())
