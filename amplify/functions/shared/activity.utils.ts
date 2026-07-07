import { Logger } from "@aws-lambda-powertools/logger";

export const logger = new Logger({
    logLevel: "INFO",
    serviceName: "activity-logger",
});

export async function createActivityRecord(
    client: any,
    userId: string,
    type: 'AGREEMENT' | 'PAYMENT' | 'DELIVERY',
    heading: string,
    supportingText: string,
    entityId: string,
    formattedAmount?: string,
    description?: string,
) {
    logger.info(`Creating ${type} Activity for user ${userId}`, { heading, entityId });

    const now = new Date().toISOString();
    const { data, errors } = await client.models.Activity.create({
        userId,
        type,
        heading,
        supportingText,
        entityId,
        formattedAmount,
        description,
        isRead: false,
        createdAt: now,
    });

    if (errors) {
        logger.error('AppSync rejected the creation (GraphQL Error)', { errors });
        throw new Error(`Failed to create Activity record: ${errors[0]?.message}`);
    }

    logger.info('Successfully created Activity record', { activityId: data?.id });
    return data;
}
