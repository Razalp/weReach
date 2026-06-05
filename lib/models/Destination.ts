import mongoose, { Schema, Document } from 'mongoose';

export interface IDestination extends Document {
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  isFavorite: boolean;
  userId: string;
  createdAt: Date;
  updatedAt: Date;
}

const DestinationSchema = new Schema<IDestination>(
  {
    name: { type: String, required: true, trim: true },
    address: { type: String, default: '' },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    isFavorite: { type: Boolean, default: false },
    userId: { type: String, default: 'anonymous', index: true },
  },
  { timestamps: true }
);

DestinationSchema.index({ userId: 1, createdAt: -1 });

export default mongoose.models.Destination ||
  mongoose.model<IDestination>('Destination', DestinationSchema);
