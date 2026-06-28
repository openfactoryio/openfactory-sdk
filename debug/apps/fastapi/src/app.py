import asyncio
import os
from typing import Annotated
from openfactory.apps import ofa_method, EventAttribute, SampleAttribute, OpenFactoryFastAPIApp
from openfactory.kafka import KSQLDBClient
from fastapi.responses import PlainTextResponse


class DemoFastAPIApp(OpenFactoryFastAPIApp):

    status = EventAttribute(value="idle", tag="App.Status")
    temperature = SampleAttribute(tag="Temperature")

    def configure_routes(self):

        @self.api.get("/")
        async def root():
            return {"status": self.status.value}

        @self.api.post("/move")
        async def move(x: float, y: float):
            self.move_axis(x, y)
            return {"message": "moving"}

        @self.api.get("/metrics", response_class=PlainTextResponse)
        def metrics():
            return (
                "# HELP demo_counter Demo counter\n"
                "# TYPE demo_counter counter\n"
                "demo_counter 42\n\n"
                "# HELP demo_temperature Temperature value\n"
                "# TYPE demo_temperature gauge\n"
                "demo_temperature 23.5\n"
            )

    @ofa_method(description="Move axis")
    def move_axis(
        self,
        x: Annotated[float, "X"],
        y: Annotated[float, "Y"]
    ):
        self.logger.info(f"Move to {x},{y}")

    async def async_main_loop(self):
        """ User override """
        while True:
            await asyncio.sleep(3)
            self.logger.info("Working hard ...")


app = DemoFastAPIApp(
    ksqlClient=KSQLDBClient(os.getenv("KSQLDB_URL", "http://localhost:8088")),
    bootstrap_servers=os.getenv("KAFKA_BROKER", "localhost:9092"),
    loglevel=os.getenv("LOG_LEVEL", "INFO")
)
app.run()
