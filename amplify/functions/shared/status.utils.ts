import { Logger } from "@aws-lambda-powertools/logger";

export const logger = new Logger({
    logLevel: "INFO",
    serviceName: "status-history-logger",
});

export async function logStatusChange(
    client: any,
    entityId: string,
    entityType: 'AGREEMENT' | 'MILESTONE',
    context: 'CORE_STATUS' | 'DELIVERY_STATUS',
    oldStatus: string | null,
    newStatus: string,
    changedBy: string
) {
    logger.info(`Creating status history for ${entityType} [${context}]`, { entityId, oldStatus, newStatus });

    const { data, errors } = await client.models.StatusHistory.create({
        entityId,
        entityType,
        context,
        oldStatus,
        newStatus,
        changedBy,
    });

    if (errors) {
        logger.error('AppSync rejected the creation (GraphQL Error)', { errors });
        throw new Error('Failed to create StatusHistory record'); // Throwing ensures batchItemFailures catches it
    }

    logger.info('Successfully created StatusHistory record via AppSync', { historyId: data?.id });
    return data;
}
